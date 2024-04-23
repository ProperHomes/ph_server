## create a new file called .env from .env-sample

## Database Setup

After creating the db, we need to create a dev role called ph_dev
`create role ph_dev login password SOME_SECURE_PASSWORD;` 

Then we can proceed with installing rambler or any other tool to run migrations.

## install rambler to migrate db

- follow the instructions here: https://github.com/elwinar/rambler

## Next check rambler.json :

- It contains the details of db, user, password that you need to setup locally.
- role should be a superuser.
- once you've your db setup. It's time to run migrations.
- run `npm run db:migrate:local` in your command line
- if something goes wrong during the migrate command then revert using `npm run db:rollback:local`
- But if migration succeeds, its time to seed your db with some fake data.
- run `npm run db:seed:local`
- Make sure the you have the .env file setup
- Now run `npm run start` and we're super.
