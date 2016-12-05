require "sinatra"
require "sinatra/reloader" if development?
require "pg"

get "/" do
  erb :home
end

get "/employees" do
  database = PG.connect(dbname: 'tiy-database')
  @rows = database.exec('SELECT * FROM employees')

  erb :employees
end

get "/new_employee" do
  erb :new_employee
end

get "/employee" do
  id = params["id"] # hash

  database = PG.connect(dbname: 'tiy-database')
  @employee = database.exec('SELECT * FROM employees where id = $1', [id]) # $1=placeholder

  erb :employee
end

post "/create_employee" do
  name = params["name"]
  address = params["address"]
  phone = params["phone"]
  salary = params["salary"]
  position = params["position"]
  github = params["github"]
  slack = params["slack"]

  database = PG.connect(dbname: "tiy-database")
  database.exec("INSERT INTO employees(name, address, phone, salary, position, github, slack) VALUES($1, $2, $3, $4, $5, $6, $7)",[name, address, phone, salary, position, github, slack])

  redirect to("/employees")
end

post "/search" do # in this case it can be either get do or post do
  # get the word query parameter from prams hash
  database = PG.connect(dbname: "tiy-database")
  word = params["word"]

  @name_search = database.exec("SELECT * FROM employees where name like $1", ["%#{word}%"])

  erb :search
end

# Do you mind explaining this part again
# ["%#{word}%"]
# why it's not %$1%
# but ["%#{word}%"]
#
# Because PG wants the %s to be part of what we are searching for
# the `name` is `like` some value
# It is the value that has the `%` as part of it
# So we wrap the `%` around the word (edited)
# Also when doing it that way, I got PG errors.
# %$1%
# The other way is:
#
# `@name_search = database.exec("SELECT * FROM employees where name like '%' || $1 || '%'", [word])`
#
# [8:51]
# `||` in PG SQL is string concatenation, kinda like    `string + string` in Ruby.


########## Question - what to do about up/ downcase when searching--
