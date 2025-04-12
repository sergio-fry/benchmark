class ApiController < ApplicationController
  def static
    render json: { hello: :world }
  end

  def db 
    render json: { count: Post.count, post: Post.find(random_id).attributes }
  end

  def cpu
    render json: { result: fibonacci(params[:n].to_i) }
  end

  private

  def fibonacci(n)
    return n if n <= 1
    fibonacci(n - 1) + fibonacci(n - 2)
  end
  
  def random_id
    rand(1..Post.count)
  end
end
