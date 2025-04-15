# GDrivePGBackup

**GDrivePGBackup** is an open-source, automated PostgreSQL backup solution that securely uploads your database dumps to **Google Drive** using [rclone](https://rclone.org/). This solution provides optional PostGIS support, automatic cleanup of old backups, and easy restoration. It is packaged with a Docker image for fast and isolated deployment.

---

## 🚀 Features

- ✅ Scheduled automatic PostgreSQL database dumps
- ☁️ Upload backups to Google Drive using rclone 
- ♻️ Automated cleanup of old backups (configurable)
- 🔁 Easy to restore from Google Drive
- 📦 Docker container for isolated and portable use
- 📆 Cron-based scheduling

---

## 🧰 Technologies Used

- [PostgreSQL Client 16](https://www.postgresql.org/)
- [Rclone](https://rclone.org/)
- [Google Drive](https://www.google.com/drive/)
- Ubuntu 22.04
- Cron

---

## 📁 Required Files in `backup-configs/`

The `backup-configs/` folder must include the following files:

- `rclone.conf` – Rclone configuration file containing the Google Drive remote setup.  
  Example entry:

  ```ini
  [gdrive]
  type = drive
  scope = drive
  service_account_file = /root/.config/rclone/gdrive_config.json
  root_folder_id
 - `gdrive_config.json` – Google Drive service account credentials file, downloaded from your Google Cloud Console. Used by rclone for authentication via the service_account_file. 


## 🐳 Docker Image

The Dockerfile is based on Ubuntu 22.04 and installs PostgreSQL client, `rclone`, and cron. It uses `start.sh` to configure and run the scheduled backups.

---

## 🔧 Configuration

Environment variables to set when running the container:

| Variable              | Description                               | Default        |
|-----------------------|-------------------------------------------|----------------|
| `POSTGRES_USER`       | PostgreSQL username                       | `docker`       |
| `POSTGRES_PASS`       | PostgreSQL password                       | `docker`       |
| `POSTGRES_HOST`       | PostgreSQL host                           | `db`           |
| `POSTGRES_PORT`       | PostgreSQL port                           | `5432`         |
| `POSTGRES_DBNAME`     | PostgreSQL database name                  | `postgres`     |
| `BUCKET`              | Google Drive folder name                  | `backups`      |
| `GD_CLEAN_DAYS_OLD`   | Days to keep backups before deletion      | `30`           |
| `BACKUP_SCHEDULE`     | Cron schedule for backups                 | `0 22 * * * `  |
| `CLEANUP_SCHEDULE`    | Cron schedule for cleaning up old backups | `0 23 * * * `   |

---

## 📂 Folder Structure
backup-configs/ │ ├── rclone.conf # Rclone config with Google Drive remote ├── gdrive_config.json # Service account credentials (for GDrive) ├── backups.sh # Backup script ├── cleanup.sh # Cleanup script └── start.sh # Entrypoint to start cron and set env

## 🐳 How to Use
You can use GDrivePGBackup either by building it locally or pulling it from Docker Hub.

### 🛠️ 1. Build Locally

#### 1. Clone the Repository

git clone https://github.com/aminenafkha1/GDrivePGBackup.git
cd GDrivePGBackup

#### 2. Build the Docker Image
docker build -t gdrive-pg-backup .

#### 3. Run the Container
 
docker run -d \
  -e POSTGRES_USER=youruser \
  -e POSTGRES_PASS=yourpass \
  -e POSTGRES_HOST=yourhost \
  -e POSTGRES_DBNAME=yourdb \
  -e GD_FOLDER=your_folder \
  -e BACKUP_SCHEDULE="*/30 * * * *" \
  -v $(pwd)/backup-configs:/backup-configs \
  gdrive-pg-backup

### 📦 2. Use Prebuilt Image from Docker Hub

#### 1. Pull the image

docker pull aminenafkha/gdrivepgbackup:latest


#### 2. Run the container:

 docker run -d \
  --name gdrivepgbackup \
  --env POSTGRES_USER=your_user \
  --env POSTGRES_PASS=your_password \
  --env POSTGRES_DBNAME=your_dbname \
  --env POSTGRES_HOST=your_db_host \
  --env BACKUP_SCHEDULE="*/30 * * * *" \
  --env CLEANUP_SCHEDULE="0 1 * * *" \
  --env BUCKET=backups \
  --env GD_CLEAN_DAYS_OLD=7 \
  -v $(pwd)/backup-configs:/backup-configs \
  aminenafkha/gdrivepgbackup
 
