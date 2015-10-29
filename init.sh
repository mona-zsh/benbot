# Shell script for initializing benbot database

# you might have to blast the benbot database by hand before recreating the database
# database.js will load pre-set quotes from before 2015/10/29

createdb benbot
coffee -c database.coffee
node database.js