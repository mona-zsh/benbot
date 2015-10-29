pg = require 'pg'
connectionString = 'postgres://localhost:5432/benbot'

Models = () ->

Models.prototype.record = (quote) ->

    data = {quote: quote}

    pg.connect connectionString, (err, client, done) -> 
        if (err)
          done()
          console.log(err)
          return {}
        client.query("INSERT INTO quotes(text) values($1)", [data.quote]);
        query = client.query("SELECT * FROM quotes ORDER BY id ASC");
        query.on 'row', (row, result) ->
        	result.addRow row;

        query.on 'end', (result) -> 
            done();
            return result;

Models.prototype.quote = (send) ->

	pg.connect connectionString, (err, client, done) ->
		if (err)
	     	done()
	     	console.log err
	     	return {}
		
		query = client.query("SELECT * FROM quotes ORDER BY date_last_quoted ASC NULLS FIRST LIMIT 1;")
		query.on 'row', (row, result) ->
			result.addRow row.text
			update = client.query("UPDATE quotes SET date_last_quoted = current_timestamp WHERE id = " + row.id + ";")
			update.on 'end', (result) ->
				done()

		query.on 'end', (result) ->
	        done()
	        return send([result.rows[0]])

module.exports = new Models();