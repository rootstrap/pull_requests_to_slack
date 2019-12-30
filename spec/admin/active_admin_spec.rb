require 'rails_helper'

describe 'activeadmin resources' do
  let(:all_resources) { ActiveAdmin.application.namespaces[:admin].resources }

  it 'should have admin user resource' do
    expect(all_resources[:AdminUser]).to be
  end

  it 'should have user resource' do
    expect(all_resources[:User]).to be
  end
end
