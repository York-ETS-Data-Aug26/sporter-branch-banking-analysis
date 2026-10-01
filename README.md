# Banking Analysis

## Setup
> It would be useful to have:
> 
> - Docker Desktop
> - IDE
> - DBeaver or SQL editor
> - Imports (Command to run down below)


```commandline
pip install --upgrade pip           

pip install "psycopg[binary,pool]"

```

You're going to make sure you're in the project by checking
your current path. If you're not you're going to change directories
by cd into the project. The last bit of your path should look like below:

```
\sporter-branch-banking-analysis
```

Next, you're going to run the following command. This command is to start the
database connection:

```
docker compose up

(When you're done with the database for the day, docker compose down
but all your data with be stored)
```

Then you can put the file into folder called `data` where you can then run the following
command. (You may or may not have to use parenthesis)
```commandline
Python main.py data/"Federal_Deposit_Insurance_Corporation_FDIC_Insured_Banks(in).csv"
```

If you did it correct you should see
```terminaloutput
Waiting on Postgresql Connection...
Creating the staging table...
Loading the CSV from data\Federal_Deposit_Insurance_Corporation_FDIC_Insured_Banks(in).csv...
Done!
```

Now in DBeaver you create a new connection with the same creditials in the docker-compose
file.

```terminaloutput
      POSTGRES_DB: fdic
      POSTGRES_USER: analyst
      POSTGRES_PASSWORD: analyst
      PORT: 5432:5432
```

**All SQL scripts will be found in the SQL folder and can be run in sequential order**