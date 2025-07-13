#include <dirent.h>
#include <sensors/sensors.h>
#include <sqlite3.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <linux/limits.h>

const char* DB_PATH             = "./sysstats.db";
const char* DB_PATH_VARENV_NAME = "MY_PC_MONITOR_DB_PATH";

typedef struct {
    int core_id;
    float freq_mhz;
} CpuFreq;

typedef struct {
    int socket_id;
    int core_id;
    float temp_c;
    float freq_mhz;
} CoreStat;

// Forward declarations for functions
void init_db(sqlite3 *db);
sqlite3_int64 insert_stats(sqlite3 *db, float cpu_temp, float gpu0_temp, float gpu1_temp, int mem_total, int mem_used);
void insert_core_stats(sqlite3 *db, sqlite3_int64 stat_id, CoreStat *stats, int count);

const char* get_database_path() {
    const char *env_path = NULL;
    env_path = getenv(DB_PATH_VARENV_NAME);
    if (env_path) {
        // A more robust check would be to see if the directory is writable.
        // For this use case, we'll keep the original logic.
        if (access(env_path, F_OK) == 0 && access(env_path, R_OK | W_OK) != 0) {
             // File exists but is not read/writeable, fallback to default.
        } else {
            return env_path;
        }
    }
    return DB_PATH;
}

float get_cpu_temp() {
    const sensors_chip_name *chip;
    const sensors_feature *feature;
    const sensors_subfeature *sub;

    float temp = 0.0;
    int c = 0;
    while ((chip = sensors_get_detected_chips(NULL, &c)) != NULL) {
        int f = 0;
        while ((feature = sensors_get_features(chip, &f)) != NULL) {
            if (feature->type == SENSORS_FEATURE_TEMP) {
                sub = sensors_get_subfeature(chip, feature, SENSORS_SUBFEATURE_TEMP_INPUT);
                if (sub && sub->flags & SENSORS_MODE_R) {
                    double val;
                    if (sensors_get_value(chip, sub->number, &val) == 0) {
                        temp = (float) val;
                        return temp; // Return the first valid temp found
                    }
                }
            }
        }
    }
    return temp;
}

int get_mem_used_mb(int *total, int *used) {
    FILE *fp = fopen("/proc/meminfo", "r");
    if (!fp) return -1;
    char line[256];
    long memTotal = 0, memAvailable = 0; // Use long to avoid overflow on systems with >2TB RAM
    while (fgets(line, sizeof(line), fp)) {
        if (sscanf(line, "MemTotal: %ld kB", &memTotal)) continue;
        if (sscanf(line, "MemAvailable: %ld kB", &memAvailable)) continue;
    }
    fclose(fp);
    *total = memTotal / 1024;
    *used = (memTotal - memAvailable) / 1024;
    return 0;
}

float get_gpu_temp(int gpu_index) {
    char *cmd = NULL;
    if (asprintf(&cmd,
        "nvidia-smi -i %d --query-gpu=temperature.gpu --format=csv,noheader,nounits",
        gpu_index) == -1) {
        perror("asprintf failed");
        return -1.0f;
    }

    FILE *fp = popen(cmd, "r");
    free(cmd);
    if (!fp) {
        perror("popen failed");
        return -1.0f;
    }

    char buf[128];
    float temp = -1.0f;
    if (fgets(buf, sizeof(buf), fp)) {
        temp = atof(buf);
    }

    pclose(fp);
    return temp;
}

int get_core_count() {
    long count = sysconf(_SC_NPROCESSORS_ONLN);
    return (count > 0) ? (int)count : 1;
}

int get_cpu_frequencies(CpuFreq *freqs, int max_count) {
    DIR *dir;
    struct dirent *entry;
    int core_count = 0;

    dir = opendir("/sys/devices/system/cpu");
    if (!dir) {
        perror("opendir /sys/devices/system/cpu");
        return -1;
    }

    while ((entry = readdir(dir)) != NULL && core_count < max_count) {
        if (sscanf(entry->d_name, "cpu%d", &freqs[core_count].core_id) == 1) {
            char path[PATH_MAX];
            snprintf(path, sizeof(path),
                     "/sys/devices/system/cpu/%s/cpufreq/scaling_cur_freq",
                     entry->d_name);

            FILE *fp = fopen(path, "r");
            if (fp) {
                int khz;
                if (fscanf(fp, "%d", &khz) == 1) {
                    freqs[core_count].freq_mhz = khz / 1000.0f;
                    core_count++;
                }
                fclose(fp);
            }
        }
    }

    closedir(dir);
    return core_count;
}

int collect_core_stats(CoreStat *core_stats, int max_count) {
    const sensors_chip_name *chip;
    const sensors_feature *feature;
    const sensors_subfeature *sub;

    CpuFreq *freqs = malloc(max_count * sizeof(CpuFreq));
    if (!freqs) {
        perror("malloc for freqs failed");
        return -1;
    }

    int freq_count = get_cpu_frequencies(freqs, max_count);
    int count = 0;
    int chip_index = 0;

    while ((chip = sensors_get_detected_chips(NULL, &chip_index)) != NULL) {
        char chip_name[PATH_MAX];
        sensors_snprintf_chip_name(chip_name, sizeof(chip_name), chip);
        if (strstr(chip_name, "coretemp")) {
            int f = 0;
            while ((feature = sensors_get_features(chip, &f)) != NULL) {
                if (feature->type == SENSORS_FEATURE_TEMP) {
                    sub = sensors_get_subfeature(chip, feature, SENSORS_SUBFEATURE_TEMP_INPUT);
                    if (sub && sub->flags & SENSORS_MODE_R) {
                        double val = 0.0;
                        if (sensors_get_value(chip, sub->number, &val) == 0) {
                            const char *label = sensors_get_label(chip, feature);
                            int core_id = -1;
                            if (label){
                                sscanf(label, "Core %d", &core_id);
                            }
                            if (core_id >= 0 && count < max_count) {
                                core_stats[count].core_id = core_id;
                                core_stats[count].socket_id = chip_index; // Note: chip_index might not be physical socket_id
                                core_stats[count].temp_c = (float)val;
                                core_stats[count].freq_mhz = 0.0f;

                                for (int i = 0; i < freq_count; i++) {
                                    if (freqs[i].core_id == core_id) {
                                        core_stats[count].freq_mhz = freqs[i].freq_mhz;
                                        break;
                                    }
                                }
                                count++;
                            }
                        }
                    }
                }
            }
        }
    }

    free(freqs);
    return count;
}

/**
 * @brief Initializes the database by creating tables if they don't exist.
 */
void init_db(sqlite3 *db) {
    char *err = 0;
    const char *sql =
        "PRAGMA foreign_keys = ON;" // It's good practice to enable foreign key constraints
        "CREATE TABLE IF NOT EXISTS stats ("
        "  id            INTEGER PRIMARY KEY AUTOINCREMENT,"
        "  timestamp     TEXT    NOT NULL,"
        "  cpu_temp      REAL,"
        "  gpu0_temp     REAL,"
        "  gpu1_temp     REAL,"
        "  mem_total_mb  INTEGER,"
        "  mem_used_mb   INTEGER"
        ");"
        "CREATE TABLE IF NOT EXISTS cpu_core_stats ("
        "  stat_id   INTEGER    NOT NULL,"
        "  socket_id INTEGER,"
        "  core_id   INTEGER,"
        "  temp      REAL,"
        "  freq_mhz  REAL,"
        "  FOREIGN KEY(stat_id) REFERENCES stats(id) ON DELETE CASCADE" // Added ON DELETE CASCADE
        ");";

    if (sqlite3_exec(db, sql, 0, 0, &err) != SQLITE_OK) {
        fprintf(stderr, "SQL error in init_db: %s\n", err);
        sqlite3_free(err);
    }
}

/**
 * @brief Inserts a record into the main 'stats' table using a prepared statement.
 * @return The rowid of the inserted record, or -1 on failure.
 */
sqlite3_int64 insert_stats(sqlite3 *db, float cpu_temp, float gpu0_temp, float gpu1_temp, int mem_total, int mem_used) {
    sqlite3_stmt *stmt;
    const char *sql = "INSERT INTO stats (timestamp, cpu_temp, gpu0_temp, gpu1_temp, mem_total_mb, mem_used_mb) "
                      "VALUES (strftime('%Y-%m-%d %H:%M:%S', 'now', 'localtime'), ?, ?, ?, ?, ?);";

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        fprintf(stderr, "Failed to prepare statement: %s\n", sqlite3_errmsg(db));
        return -1;
    }

    sqlite3_bind_double(stmt, 1, cpu_temp);
    sqlite3_bind_double(stmt, 2, gpu0_temp);
    sqlite3_bind_double(stmt, 3, gpu1_temp);
    sqlite3_bind_int(stmt, 4, mem_total);
    sqlite3_bind_int(stmt, 5, mem_used);

    sqlite3_int64 last_id = -1;
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        last_id = sqlite3_last_insert_rowid(db);
    } else {
        fprintf(stderr, "Failed to execute insert_stats statement: %s\n", sqlite3_errmsg(db));
    }

    sqlite3_finalize(stmt);
    return last_id;
}

/**
 * @brief Inserts core stat records linked to a parent stat record.
 * Uses a transaction for performance.
 */
void insert_core_stats(sqlite3 *db, sqlite3_int64 stat_id, CoreStat *stats, int count) {
    sqlite3_stmt *stmt;
    const char *sql = "INSERT INTO cpu_core_stats (stat_id, socket_id, core_id, temp, freq_mhz) "
                      "VALUES (?, ?, ?, ?, ?);";

    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
        fprintf(stderr, "Failed to prepare statement for core stats: %s\n", sqlite3_errmsg(db));
        return;
    }

    // Use a transaction for bulk inserts for much better performance.
    sqlite3_exec(db, "BEGIN TRANSACTION;", NULL, NULL, NULL);

    for (int i = 0; i < count; i++) {
        sqlite3_bind_int64(stmt, 1, stat_id);
        sqlite3_bind_int(stmt, 2, stats[i].socket_id);
        sqlite3_bind_int(stmt, 3, stats[i].core_id);
        sqlite3_bind_double(stmt, 4, stats[i].temp_c);
        sqlite3_bind_double(stmt, 5, stats[i].freq_mhz);

        if (sqlite3_step(stmt) != SQLITE_DONE) {
            fprintf(stderr, "Failed to insert core stat row: %s\n", sqlite3_errmsg(db));
        }

        sqlite3_reset(stmt); // Reset bindings for the next iteration
    }

    sqlite3_exec(db, "COMMIT;", NULL, NULL, NULL);
    sqlite3_finalize(stmt);
}

int main() {
    if (sensors_init(NULL) != 0) {
        fprintf(stderr, "Failed to initialize sensors library.\n");
        return 1;
    }

    sqlite3 *db;
    if (sqlite3_open(get_database_path(), &db) != SQLITE_OK) {
        fprintf(stderr, "Failed to open database: %s\n", sqlite3_errmsg(db));
        sensors_cleanup();
        return 1;
    }

    init_db(db);

    float cpu = get_cpu_temp();
    float gpu0 = get_gpu_temp(0);
    float gpu1 = get_gpu_temp(1);
    int mem_total = 0, mem_used = 0;
    get_mem_used_mb(&mem_total, &mem_used);

    int core_count = get_core_count();
    CoreStat *core_stats = calloc(core_count, sizeof(CoreStat));
    if (!core_stats) {
        perror("calloc for core_stats failed");
        sqlite3_close(db);
        sensors_cleanup();
        return 1;
    }
    int collected_core_count = collect_core_stats(core_stats, core_count);

    sqlite3_int64 stat_id = insert_stats(db, cpu, gpu0, gpu1, mem_total, mem_used);

    if (stat_id > 0 && collected_core_count > 0) {
        insert_core_stats(db, stat_id, core_stats, collected_core_count);
    }

    free(core_stats);
    sqlite3_close(db);
    sensors_cleanup();

    printf("System stats collected successfully.\n");
    return 0;
}
