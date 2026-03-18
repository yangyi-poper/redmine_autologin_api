class AutologinTokensController < ApplicationController
  accept_api_auth :create, :destroy, :test

  before_action :require_admin, except: [:test]

  # POST /api/autologin_tokens.json
  # 参数: user_id (Redmine 用户 ID)
  def create
    user = User.find_by(id: params[:user_id])

    if user.nil?
      Rails.logger.warn "[Autologin API] User not found: #{params[:user_id]}, operator: #{User.current.login}, ip: #{request.remote_ip}"
      render json: { error: 'User not found' }, status: :not_found
      return
    end

    # 删除该用户的旧 autologin token
    Token.where(user_id: user.id, action: 'autologin').delete_all

    # 生成新 token
    token_value = SecureRandom.hex(20)
    token = Token.create!(
      user: user,
      action: 'autologin',
      value: token_value,
      created_on: Time.now
    )

    Rails.logger.info "[Autologin API] Generated token for user #{user.login} (#{user.id}), operator: #{User.current.login}, ip: #{request.remote_ip}"

    render json: {
      success: true,
      user_id: user.id,
      login: user.login,
      token: token.value
    }
  rescue => e
    Rails.logger.error "[Autologin API] Error generating token: #{e.message}\n#{e.backtrace.join("\n")}"
    render json: { error: 'Failed to generate token' }, status: :internal_server_error
  end

  # DELETE /api/autologin_tokens/:user_id.json
  def destroy
    deleted_count = Token.where(user_id: params[:user_id], action: 'autologin').delete_all

    Rails.logger.info "[Autologin API] Deleted #{deleted_count} tokens for user #{params[:user_id]}, operator: #{User.current.login}, ip: #{request.remote_ip}"

    render json: {
      success: true,
      deleted_count: deleted_count
    }
  rescue => e
    Rails.logger.error "[Autologin API] Error deleting token: #{e.message}\n#{e.backtrace.join("\n")}"
    render json: { error: 'Failed to delete token' }, status: :internal_server_error
  end

  # GET /api/autologin_tokens/test.json
  # 测试接口，验证插件是否正常工作
  def test
    render json: {
      plugin: 'redmine_autologin_api',
      version: '1.0.0',
      status: 'ok',
      current_user: User.current.logged? ? User.current.login : 'anonymous',
      is_admin: User.current.admin?
    }
  end

  private

  def require_admin
    unless User.current.admin?
      render json: { error: 'Admin permission required' }, status: :forbidden
    end
  end
end
