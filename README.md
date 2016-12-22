# Tagathon Display Dashboard

This web app displays a dashboard containing statistics pulled from a Google
Sheets spreadsheet.

It was build primarily for the GOV.UK Finding Things team Tagathon event to
display statistics during the day of the event.

## Running locally

To run the server you will need the following `ENV` variables set:

```
CLIENT_ID
CLIENT_SECRET
REFRESH_TOKEN
SPREADSHEET_ID
SPREADSHEET_RANGE
```

You can create the client ID and client secret using the [Google developer
console][1]. You need to generate the refresh token; there is a [short Ruby
script to create one for you][2].

You can get the spreadsheet ID from the sharing URL for the spreadsheet:

`https://docs.google.com/spreadsheets/d/**14iKMlhtBwpjjM1qNBmdPL7Lexsb7Af9PbokGRXEOwrQ**/edit`

You also need the range in the spreadsheet to get the statistics from; for
example:

`Statistics!A1:B12`

The range must always cover two columns - the first one with the name of the
statistic and the second with the value. Any row without content in both
columns will be ignored.

Once you have completed the setup, you can start the server by running:

```
CLIENT_ID=... CLIENT_SECRET=... REFRESH_TOKEN=... SPREADSHEET_ID=... SPREADSHEET_RANGE=... ruby ./server.rb
```

If you set the `USERNAME` and `PASSWORD` environment variables then the
app will be protected with HTTP Basic Auth.

[1]: https://console.developers.google.com/
[2]: generate_refresh_token.rb

## Licence

[MIT License](LICENSE)
