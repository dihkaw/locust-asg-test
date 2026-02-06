import logging
from locust import HttpUser, task, between, events

# Setup logging
logging.basicConfig(level=logging.INFO)

class ASGLoadTest(HttpUser):
    wait_time = between(1, 5)

    @task(3)
    def access_homepage(self):
        with self.client.get("/", catch_response=True) as response:
            if response.status_code == 200:
                if "Welcome" in response.text or "App" in response.text:
                    response.success()
                else:
                    response.failure("Response 200 tapi konten tidak sesuai")
            elif response.status_code == 502:
                response.failure("502 Bad Gateway: Instance belum In-Service")
            elif response.status_code == 504:
                response.failure("504 Gateway Timeout: Instance Overload")
            else:
                response.failure(f"Error: {response.status_code}")

    @task(1)
    def cpu_intensive_task(self):
        # Sesuaikan endpoint ini dengan aplikasi Anda
        with self.client.get("/heavy-compute", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Heavy task error: {response.status_code}")


# Gunakan @events.test_stop.add_listener atau langsung @events.test_stop
@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    print("\n" + "="*30)
    print("      PENGUJIAN SELESAI")
    print("="*30)
    if environment.stats.total.num_failures > 0:
        print(f"Total Kegagalan: {environment.stats.total.num_failures}")
    else:
        print("Status: Sistem Sangat Stabil.")
    print("="*30 + "\n")