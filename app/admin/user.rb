ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :github_name, :blacklisted

  form do |f|
    f.inputs 'Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :github_name
      f.input :blacklisted
    end

    actions
  end

  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :github_name
    column :blacklisted
    column :created_at
    column :updated_at
    actions
  end

  filter :id
  filter :email
  filter :github_name
  filter :first_name
  filter :last_name
  filter :blacklisted
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :github_name
      row :blacklisted
      row :created_at
      row :updated_at
    end
  end
end
