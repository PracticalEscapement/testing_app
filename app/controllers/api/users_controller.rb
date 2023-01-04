class Api::UsersController < ApplicationController

  before_action :authenticate_current_user

  def index
    @direct_reports = current_user.direct_reports
    render json: @direct_reports
  end

  def update
    user = current_user.direct_reports.find_by(id: params[:id])
    if user.nil?
      head(:forbidden)
    else
      user.update!(user_params)
      render json: user
    end
  end

  def create
    user = User.create(user_params.merge(manager: current_user))

    if user.persisted?
      render json: user
    else
      head(:bad_request)
    end
  end

  def destroy
    user_to_delete = current_user.direct_reports.find_by(id: params[:id])
    if user_to_delete.present?
      user_to_delete.destroy
      render json: user_to_delete
    else  
      head(:forbidden)
    end
  end

  private

  def user_params 
    params.require(:user).permit(
      :first_name, 
      :last_name,
      :password,
      :title
    )
  end

  
end
