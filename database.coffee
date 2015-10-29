pg = require 'pg'

quotes = []

connectionString = 'postgres://localhost:5432/benbot';
console.log connectionString;

client = new pg.Client(connectionString);
client.connect()
query = client.query('CREATE TABLE quotes(id SERIAL PRIMARY KEY, text VARCHAR(255) not null, date_last_quoted TIMESTAMP)');
console.log 'createdb benbot'

query.on 'end', (result) ->
	console.log 'query end'
	loadData()

loadData = () ->
	readline = require 'linebyline'
	data = 'data.txt'
	rl = readline(data)
	rl.on 'line', (line) ->
		console.log('Line from file:', line);
		quotes.push(line)
	rl.on 'close', ->
		query
		for quote in quotes
			query = client.query("INSERT INTO quotes(text) values($1)", [quote])
			console.log 'insert', query.text
		query.on 'end', ->
			console.log 'query end'
			client.end()
		query.on 'error', (error) ->
			console.log error