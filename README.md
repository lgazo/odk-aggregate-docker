# odk-aggregate-docker
ODK aggregate docker

This docker images uses ODK Aggregate 1.4.12.

This docker image requires the following environment variables to function properly:

```
ODK_HOSTNAME #this should be your domain name or public ip
ODK_ADMIN_USERNAME
ODK_AUTH_REALM #what should be sent to users when BasicAuth or DigestAuth is done
DATABASE_URL #should be in the format of "jdbc:postgresql://host:port/db_name"
POSTGRES_USER
POSTGRES_PASSWORD
```

For example, you can run it like this:
```
docker run -p 8080:8080 --env-file .env  odk
```

The .env file should contain all env vars listed above.
