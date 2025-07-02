#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sqlite3.h>
#include <sensors/sensors.h>
#include <time.h>

#define DB_PATH "./sysstats.db"

float get_cpu_temp() {
    const sensors_chip_name *chip;
    const sensors_feature *feature;
    const sensors_subfeature *sub;

    sensors_init(NULL);
    float temp = 0.0;

    int c = 0;
    while ((chip = sensors_get_detected_chips(NULL, &c)) != NULL) {
        int f = 0;
        while ((feature = sensors_get_features(chip, &f)) != NULL) {
            if (feature->type == SENSORS_FEATURE_TEMP) {
                sub = sensors_get_subfeature(chip, feature, SENSORS_SUBFEATURE_TEMP_INPUT);
                if (sub && sub->flags & SENSORS_MODE_R) {
                    double val;
                    sensors_get_value(chip, sub->number, &val);
                    temp = (float) val;
                    break;
                }
            }
        }
    }
    sensors_cleanup();
    return temp;
}

int get_mem_used_mb(int *total, int *used) {
    FILE *fp = fopen("/proc/meminfo", "r");
    if (!fp) return -1;
    char line[256];
    int memTotal = 0, memAvailable = 0;
    while (fgets(line, sizeof(line), fp)) {
        if (sscanf(line, "MemTotal: %d kB", &memTotal)) continue;
        if (sscanf(line, "MemAvailable: %d kB", &memAvailable)) continue;
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
        return -1;
    }

    FILE *fp = popen(cmd, "r");
    free(cmd);

    if (!fp) return -1;

    char buf[128];
    if (!fgets(buf, sizeof(buf), fp)) {
        pclose(fp);
        return -1;
    }

    pclose(fp);
    return atof(buf);
}


void insert_stats(sqlite3 *db, float cpu_temp, float gpu0_temp, float gpu1_temp, int mem_total, int mem_used) {
    char *err = 0;
    char sql[512];
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    char timestamp[64];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", t);

    snprintf(sql, sizeof(sql),
        "INSERT INTO stats (timestamp, cpu_temp, gpu0_temp, gpu1_temp, mem_total_mb, mem_used_mb) "
        "VALUES ('%s', %.2f, %.2f, %.2f, %d, %d);",
        timestamp, cpu_temp, gpu0_temp, gpu1_temp, mem_total, mem_used);

    if (sqlite3_exec(db, sql, 0, 0, &err) != SQLITE_OK) {
        fprintf(stderr, "SQL error: %s\n", err);
        sqlite3_free(err);
    }
}

int main() {
    sqlite3 *db;
    sqlite3_open(DB_PATH, &db);

    const char *create_sql =
        "CREATE TABLE IF NOT EXISTS stats ("
        "timestamp TEXT, "
        "cpu_temp REAL, "
        "gpu0_temp REAL, "
        "gpu1_temp REAL, "
        "mem_total_mb INTEGER, "
        "mem_used_mb INTEGER);";
    char *err = 0;
    sqlite3_exec(db, create_sql, 0, 0, &err);

    float cpu = get_cpu_temp();
    float gpu0 = get_gpu_temp(0);
    float gpu1 = get_gpu_temp(1);
    int mem_total = 0, mem_used = 0;
    get_mem_used_mb(&mem_total, &mem_used);

    insert_stats(db, cpu, gpu0, gpu1, mem_total, mem_used);

    sqlite3_close(db);
    return 0;
}
