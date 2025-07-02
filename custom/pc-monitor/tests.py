import shutil
import unittest
import sqlite3
import os
import subprocess

EXECUTABLE = "./pc-monitor"
DB_PATH = "./sysstats.db"
FAKE_NVIDIA_SMI_PATH = "./fake_nvidia_smi"

FAKE_NVIDIA_SMI_OUTPUT = """Wed Jul  2 18:08:23 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.153.02             Driver Version: 570.153.02     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3090        Off |   00000000:03:00.0  On |                  N/A |
| 30%   46C    P8             37W /  350W |     644MiB /  24576MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA GeForce RTX 3090        Off |   00000000:81:00.0 Off |                  N/A |
| 30%   48C    P8             19W /  350W |      15MiB /  24576MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            6187      G   ...mjm-xorg-server-21.1.16/bin/X        273MiB |
|    0   N/A  N/A            6225      G   ...c/gnome-remote-desktop-daemon          4MiB |
|    0   N/A  N/A            6277      G   ...me-shell-48.1/bin/gnome-shell         46MiB |
|    0   N/A  N/A            6942      G   ...fulano/.nix-profile/bin/kitty          8MiB |
|    0   N/A  N/A            7137      G   ...-139.0.1/bin/.firefox-wrapped        183MiB |
|    1   N/A  N/A            6187      G   ...mjm-xorg-server-21.1.16/bin/X          4MiB |
+-----------------------------------------------------------------------------------------+
"""
def create_fake_nvidia_smi():
    with open(FAKE_NVIDIA_SMI_PATH, "w") as f:
        f.write("#!/bin/bash\n")
        f.write(f"echo '{FAKE_NVIDIA_SMI_OUTPUT}'\n")
    os.chmod(FAKE_NVIDIA_SMI_PATH, 0o755)


class TestPCMonitor(unittest.TestCase):
    def setUp(self):
        if os.path.exists(DB_PATH):
            os.remove(DB_PATH)
        if os.path.exists(EXECUTABLE):
            os.remove(EXECUTABLE)

        # Capture compilation output
        self.compile_result = subprocess.run(
            ["gcc", "main.c", "-o", EXECUTABLE, "-lsqlite3", "-lsensors", "-Wall"],
            capture_output=True, text=True
        )

        self.compile_warnings = self.compile_result.stderr.strip().splitlines()
        self.compile_success = (self.compile_result.returncode == 0)


    def tearDown(self):
        """
        This method is called after each test. It cleans up artifacts.
        """
        if os.path.exists(DB_PATH):
            os.remove(DB_PATH)
        if os.path.exists(EXECUTABLE):
            os.remove(EXECUTABLE)
        if os.path.exists(FAKE_NVIDIA_SMI_PATH):
            os.remove(FAKE_NVIDIA_SMI_PATH)


    def test_no_warnings_accepted(self):
        warning_count = sum(1 for line in self.compile_warnings if "warning:" in line)
        print(f"Compile warnings: {warning_count}")
        self.assertEqual(warning_count, 0, "Compiler warnings not accepted!")

    def test_program_creates_db_and_inserts_one_row(self):
        """
        Tests if running the program creates the database and inserts exactly
        one row of data with the correct structure.
        """

        if shutil.which("nvidia-smi") is None:
            create_fake_nvidia_smi()
            env = os.environ.copy()
            env["PATH"] = os.path.abspath(".") + os.pathsep + env["PATH"]

    # 1. Run the compiled C program
        run_result = subprocess.run([EXECUTABLE], capture_output=True, text=True)
        self.assertEqual(run_result.returncode, 0, f"Program execution failed: {run_result.stderr}")


    # 2. Check if the database file was created
        self.assertTrue(os.path.exists(DB_PATH), "Database file was not created.")

    # 3. Connect to the database and verify its contents
        with sqlite3.connect(DB_PATH) as con:
            cursor = con.cursor()
            # Query the table to get all inserted data
            cursor.execute("SELECT * FROM stats;")
            rows = cursor.fetchall()

    # 4. Assert that exactly one row was inserted
            self.assertEqual(len(rows), 1, f"Expected 1 row in 'stats' table, but found {len(rows)}")

    # 5. Perform basic sanity checks on the data types and values
            row = rows[0]
            timestamp, cpu_temp, gpu0_temp, gpu1_temp, mem_total, mem_used = row

            self.assertIsInstance(timestamp, str)
            self.assertIsInstance(cpu_temp, float)
            # GPU temp can be -1.0 if nvidia-smi fails, which is a valid test case
            self.assertIsInstance(gpu0_temp, float)
            self.assertIsInstance(gpu1_temp, float)
            self.assertIsInstance(mem_total, int)
            self.assertIsInstance(mem_used, int)

            # Check for plausible values
            self.assertGreater(mem_total, 0, "Total memory should be a positive number.")
            self.assertGreaterEqual(mem_used, 0, "Used memory should be non-negative.")


if __name__ == '__main__':
    unittest.main()