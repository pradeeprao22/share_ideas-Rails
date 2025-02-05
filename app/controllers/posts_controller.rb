class PostsController < ApplicationController
  include ActionController::Cookies
  include BackendRunner
  include VisitorDetail
  include CreateNotification
  include CodeFilesource
  # layout "frontpage"
  before_action :authenticate_user!, only: %i[destroy create module_post]
  before_action :find_post, only: %i[show destroy build_module]
  before_action :set_cookie, only: [:index]
  # Quick fix
  skip_before_action :verify_authenticity_token, only: [:create]

  def index
    # For getting user details
    action = params[:action]
    getdetails(action)

    @posts = Post.where(published: true).paginate(page: params[:page], per_page: 9).includes(:photos, :user,
                                                                                             :likes, :bookmarks).order('created_at asc')
    # redirect_to posts_path
    # respond_to do |format|
    #   format.js {render layout: false}
    #   format.html { render 'index'}
    # end
    if !@posts.nil?
      @posts.map do |post|
        ImgkitWorker.perform_async(post.slug, post.id) if ImageRepo.find_by(post_id: post.id).nil?
      end
    else
      flash[:warning] = 'No Posts'
    end
  end

  def create
    # For getting user details
    action = params[:action]
    getdetails(action)
    # Removing the empty elements in array
    tags = params[:post][:tags_id].delete_if { |element| element.empty? }

    @post = current_user.posts.build(post_params)
    # Tags allocate
    @post.tags_id = tags
    begin
      ActiveRecord::Base.transaction do
        if @post.save!
          # For creating notification
          notify(action, @post)

          # Code File Module
          code_file_create(@post)
        end
      rescue ActiveRecord::RecordInvalid => e
        puts e
        flash[:warning] = "Module not saved #{e}"
      rescue StandardError => e
        puts e
        flash[:warning] = "Module not saved #{e}"
      end

      ActionCable.server.broadcast('post_channel', { post: (render @post) })
      flash[:success] = 'Module created succesfully'
      head :ok
      # redirect_to posts_path
    end
  end

  def update
    # for getting user details
    action = params[:action]
    getdetails(action)

    @post = current_user.posts.find_by(slug: params[:slug])
    @post.update(post_params)
    redirect_to post_path
    flash[:notice] = 'Module updated succesfully.'
  end

  def show
    # for getting user details
    action = params[:action]
    getdetails(action)

    @photos = @post.photos
    @post = @post
    @likes = @post.likes.includes(:user)
    @comment = Comment.new
    @is_liked = @post.is_liked(current_user)
    @is_bookmarked = @post.is_bookmarked(current_user)
    @image_path = @post.slug
  end

  def destroy
    # for getting user details
    action = params[:action]
    getdetails(action)

    flash[:notice] = if @post.user == current_user
                       if @post.update(published: false)
                         'Post deleted!'
                       else
                         'Something went wrong ...'
                       end
                     else
                       "You don't have permission to do that!"
                     end
    redirect_to user_path(current_user)
  end

  def module_post
    @post = Post.new
  end

  def build_module
    if ImageRepo.find_by(post_id: @post.id).nil?
      slug = @post.slug
      post_id = @post.id
      ImgkitWorker.perform_async(slug, post_id)
    end
    # for getting user details
    action = params[:action]
    getdetails(action)

    # under dev
    get_backend_code(@post.id)

    @photos = @post.photos
    @likes = @post.likes.includes(:user)
    @comment = Comment.new
    @is_liked = @post.is_liked(current_user)
    @is_bookmarked = @post.is_bookmarked(current_user)
  end

  # under dev
  def import_module
    post = @post

    # In Dev
    @import = Import.create(import_client: params[:import_client], user_id: current_user.id, post_id: @post.id)
  end

  # under dev
  def backend_module_execution
    code_execute
  end

  private

  def code_fileupload; end

  def find_post
    @post = Post.friendly.find_by_slug(params[:slug])

    return if @post

    flash[:danger] = 'Post not exist!'
    redirect_to root_path
  end

  def post_params
    params.require(:post).permit(:content, :frontend, :javascript, :backend, :frontend_css, :database, :instruction, :slug, :module_type, :tags_id,
                                 code_file_attributes: %i[id name file_type post_id user_id post_column])
  end

  def set_cookie
    return unless cookies[:verified_user] && current_user

    cookies[:verified_user] = current_user.id
    verified_user = cookies[:verified_user]
  end
end
