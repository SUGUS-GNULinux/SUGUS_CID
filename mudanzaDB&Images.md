## Comandos mudanza DB

1. Copiar la clave de la DB del archivo `~/Shipmee_CID_Workspace/generatedPasswords.log`

2. Ejecutar comando exportación archivo 

```
docker exec Shipmee-master-mysql \
    bash -c "exec mysqldump -uroot -pNjY1MTViNvggvghI4N2Q3Y2Y3MmJjNTZi Shipmee" > /home/core/master_dump.sql
```

3. [OPCIONAL] Traer el archivo a nuestro ordenador y enviarlo a la nueva máquina:

```
scp core@178.62.71.60:/home/core/master_dump.sql /home/manolo/Downloads
```
```
scp /home/manolo/Downloads/master_dump.sql core@188.166.10.38:/home/core/master_dump.sql
```

4. Obtener otra contraseña DB de `~/Shipmee_CID_Workspace/generatedPasswords.log`

5. Cargando dump en la base de datos

```
docker cp /home/core/master_dump.sql Shipmee-master-mysql:/home/user/dump.sql
```

```
docker exec Shipmee-master-mysql \
    bash -c "exec mysql -uroot -pYjc4tyftyfytuyftfyMzMjkwOGUxMDA5OTNlNjgy Shipmee < /home/user/dump.sql"
```

```
docker exec Shipmee-master-mysql \
    bash -c "exec rm /home/user/dump.sql"
```

## Comandos mudanza imágenes

1. Comprimimos la carpeta para facilitar el movimiento

```
tar cvf /home/core/imagenes.tar -C /home/core/Shipmee_CID_Workspace/deploys/Shipmee/master/images/ \
    $(ls /home/core/Shipmee_CID_Workspace/deploys/Shipmee/master/images/)
```

2. Traer el archivo a nuestro ordenador y enviarlo a la nueva máquina:

```
scp core@178.62.71.60:/home/core/imagenes.tar /home/manolo/Downloads
```
```
scp /home/manolo/Downloads/imagenes.tar core@188.166.10.38:/home/core/imagenes.tar
```

3. Decomprimimos en la ruta deseada

```
tar xvf /home/core/imagenes.tar -C /home/core/Shipmee_CID_Workspace/deploys/Shipmee/master/images/
```



