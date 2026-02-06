# 🚀 ASG Replication & Load Testing with Locust

Repositori ini berisi workflow otomatis menggunakan **GitHub Actions** dan **Locust** untuk menguji mekanisme *Auto Scaling Group* (ASG) pada infrastruktur AWS. Workflow ini mensimulasikan beban trafik tinggi untuk memicu replikasi instance EC2 dan mencatat performanya secara real-time.

## 📊 Fitur Utama
* **Dynamic Load Injection**: Konfigurasi jumlah user, spawn rate, dan durasi melalui variabel environment.
* **Real-time ASG Monitoring**: Mencatat jumlah instance EC2 yang berjalan setiap menit ke dalam file CSV.
* **Comprehensive Reports**: Menghasilkan laporan performa interaktif dalam format HTML.
* **Automated Infrastructure Testing**: Memastikan kebijakan scaling (CPU Threshold) Anda bekerja sesuai harapan.

---

## ⚙️ Persiapan (Prerequisites)

Sebelum menjalankan workflow, pastikan Anda telah menyiapkan hal-hal berikut di AWS:
1.  **Auto Scaling Group**: Sudah terkonfigurasi dengan kebijakan scaling (misal: Scale out jika CPU > 50%).
2.  **Application Load Balancer (ALB)**: Sebagai titik masuk trafik.
3.  **IAM User**: Memiliki izin `AmazonEC2ReadOnlyAccess` untuk memantau jumlah instance.

### Konfigurasi GitHub Secrets
Buka repositori Anda di GitHub, pergi ke **Settings > Secrets and variables > Actions**, dan tambahkan secret berikut:

| Nama Secret | Deskripsi |
| :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Access Key ID akun AWS Anda |
| `AWS_SECRET_ACCESS_KEY` | Secret Access Key akun AWS Anda |
| `AWS_SESSION_TOKEN` | (Opsional) Diperlukan jika menggunakan AWS Academy/Temporary Credentials |
| `AWS_REGION` | Region tempat ASG berada (contoh: `us-east-1`) |
| `ALB_URL` | URL DNS dari Load Balancer Anda (contoh: `http://my-alb-123.aws.com`) |

---

## 🚀 Cara Penggunaan

1.  Masuk ke tab **Actions** di repositori GitHub Anda.
2.  Pilih workflow **ASG Replication Load Test - Dynamic** di sisi kiri.
3.  Klik dropdown **Run workflow**.
4.  (Opsional) Ubah nilai parameter jika diperlukan langsung di file YAML:
    * `TEST_USERS`: Target jumlah user serentak.
    * `TEST_SPAWN_RATE`: Jumlah user yang bertambah setiap detik.
    * `TEST_RUN_TIME`: Durasi pengujian (contoh: `10m` untuk 10 menit).
5.  Klik **Run workflow**.

---

## 📂 Output Pengujian
Setelah workflow selesai, Anda dapat mengunduh **Artifacts** bernama `load-test-results` yang berisi:

### 1. `stress_test_report.html`
Laporan visual dari Locust yang menunjukkan:
* **Requests Per Second (RPS)**: Seberapa banyak trafik yang bisa ditangani.
* **Response Time (Latency)**: Waktu respons server (Median & Percentile).
* **Failures**: Jumlah error (seperti 502 Bad Gateway) yang muncul saat scaling terjadi.

### 2. `instance_metrics.csv`
Data mentah yang mencatat jumlah EC2 Running setiap menit. Formatnya:
```csv
Timestamp,RunningInstances
2026-02-06T05:41:42Z,2
2026-02-06T05:42:42Z,2
2026-02-06T05:43:42Z,4
```

---

## 💡 Tips Analisis Scaling
Jika jumlah instance tidak bertambah di file CSV:
* **Periksa Threshold CPU**: Pastikan beban dari Locust cukup besar untuk melewati ambang batas CPU di AWS Scaling Policy.
* **Cek CloudWatch Alarms**: Lihat apakah alarm masuk ke status In alarm.
* **Waktu Durasi**: AWS membutuhkan waktu untuk deteksi dan provisioning. Gunakan TEST_RUN_TIME minimal 10 menit untuk hasil yang lebih valid.

---

## 🛠️ Struktur Workflow YAML
Workflow ini bekerja dengan urutan:
1. **Checkout & Setup**: Menyiapkan environment Python dan AWS CLI.
2. **Background Monitor**: Menjalankan script shell di latar belakang untuk mencatat jumlah instance ke CSV setiap 60 detik.
3. **Locust Execution**: Menjalankan pengujian trafik secara headless.
4. **Artifact Upload**: Mengumpulkan semua hasil pengujian untuk dianalisis.
