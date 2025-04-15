#!/bin/bash
echo "Starting the program..."

cd /home/servidor
mkdir -p logs
mkdir -p backup_db

DB_NAME="tibia"
DB_USER="root"
DB_PASS="1@#oldzen@@"
BACKUP_DELAY_SECONDS=3600  # 1 hora
LAST_BACKUP_FILE="last_backup_time"

ulimit -c unlimited
set -o pipefail

while true
do
    gdb --batch \
        -ex "set print thread-events off" \
        -ex "set scheduler-locking off" \
        -return-child-result \
        --command=antirollback_config \
        --args ./tfs 2>&1 | \
        awk '{ print strftime("%F %T - "), $0; fflush(); }' | \
        tee "logs/$(date +"%F %H-%M-%S.log")"

    exit_code=$?

    echo "TFS finalizado (exit code: $exit_code). Verificando necessidade de backup..."

    current_time=$(date +%s)
    last_backup_time=0

    if [ -f "$LAST_BACKUP_FILE" ]; then
        last_backup_time=$(cat "$LAST_BACKUP_FILE")
    fi

    time_diff=$((current_time - last_backup_time))

    if [ $time_diff -ge $BACKUP_DELAY_SECONDS ]; then
        echo "Último backup foi há mais de 1 hora. Criando novo backup da database..."
        mysqldump --single-transaction -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "backup_db/backup_$(date +%d-%m-%Y_%H-%M-%S).sql"

        if [ $? -eq 0 ]; then
            echo "Backup criado com sucesso!"
            echo $current_time > "$LAST_BACKUP_FILE"
        else
            echo "Falha ao criar o backup da database!"
        fi
    else
        echo "Backup ignorado (último foi há menos de 1 hora - $((time_diff / 60)) hora atrás)."
    fi

    if [ $exit_code -eq 0 ]; then
        echo "TFS saiu normalmente. Aguardando 3 minutos antes de reiniciar..."
        sleep 180
    else
        echo "Reiniciando o servidor em 5 segundos..."
        sleep 5
    fi
done
