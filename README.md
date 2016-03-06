# Passity

## Description

Passity is a web-based highly secured password keeper.

It handle multi-user account, password permission by user or group of user and
three level of roles for the users.

## Installation

Clone the git repository:
```
git clone git@github.com:corpille/passity.git
```

Launch the install script :
```
cd passity/
sh install.sh
```

# Initialization

Before launching anything you need to create a database for Passity to store the
passwords. Create an empty database (default name would be passity) with a specific
user.

Once created you need to fill up the configuration file in `bin/config/config.yaml`:
```
postgres:
  url: "localhost"
  port: "5432"
  dbName: "passity"
  login: "passity"
  password: "password"
```

Where the parameters are:
- **url**: The url on which your postgres server runs
- **port**: The port used by your postgres server
- **dbName**: The database name you created earlier
- **login**: The login of the user you created earlier
- **password**: The password of the user you created earlier

# Running Passity

TODO
