class ApiController < ApplicationController
  def static
    render json: { hello: :world }
  end

  def db
    populate_database if no_posts?
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
    Post.select(:id).order("random()").first.id
  end

  def no_posts? = Post.count == 0

  def populate_database
    1000.times { |n| Post.create(title: "Title #{n}", content: "Some content") }
  end
end
