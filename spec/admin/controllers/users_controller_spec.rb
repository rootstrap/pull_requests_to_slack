describe Admin::UsersController, type: :controller do
  describe 'index' do
    it 'redirect to login page when not logged in' do
      get :index
      expect(response).to redirect_to new_admin_user_session_path
    end
  end
end
