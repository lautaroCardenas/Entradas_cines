json.extract! @user, :id, :name, :email_address, :created_at
json.orders_count @user.orders.count
json.token @token if @token
