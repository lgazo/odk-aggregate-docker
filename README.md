
# Version

This docker images uses ODK Aggregate **1.4.12** from: https://opendatakit.org/downloads/download-info/odk-aggregate-osx-installer-app-zip/

# Required env vars
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
docker run -p 8080:8080 --env-file .env cuipengfei/odk-aggregate
```

The .env file should contain all env vars listed above. You can refer to the .env file in this repo as template.

# The tricks

When you start a container of this docker image, it runs the **run.sh** script, which does some tricky things like **exploding and reassembling** jar and war file, here is why:

ODK provides an installer, when you run the installer, you are required to input information that correspond to the env vars mentioned above.

The installer takes the input and put it in properties files, then put the properties files in a jar file, then put that jar in a war file. The war file is the final output of the installer.

When starting a docker container, we can not run the installer, since it has **GUI**. So the image packages in a pre-generated war file, then at run time explode the war, replace strings in properties files with the env vars, then reassembles the war file.
