class App < Sinatra::Base
	enable :sessions
	get '/' do
		slim:index
	end


	get('/register') do
		slim :register
	end

	post '/login' do
		db = SQLite3::Database.new("main.sqlite") 
		username = params["username"] 
		password = params["password"]
		accounts = db.execute("SELECT * FROM login WHERE username=?", username)
		account_password = BCrypt::Password.new(accounts[0][2])

		if account_password == password
			result = db.execute("SELECT id FROM login WHERE username=?", [username]) 
			session[:id] = accounts[0][0] 
			session[:login] = true 
		elsif password == nil
			redirect("/error")
		else
			session[:login] = false
		end
		redirect('/')
	end

	get '/register' do
		slim(:register) 
	end

	post '/register' do
		db = SQLite3::Database.new('main.sqlite')
		username = params["username"]
		password = params["password"]
		confirm = params["password2"]
		if confirm == password
			begin
				password_encrypted = BCrypt::Password.create(password)
				db.execute("INSERT INTO login('username' , 'password') VALUES(? , ?)", [username,password_encrypted])
				redirect('/signup_successful')

			rescue 
				session[:message] = "Username is not available"
				redirect("/error")
			end
		else
			session[:message] = "Password does not match"
			redirect("/error")
		end
	end
end