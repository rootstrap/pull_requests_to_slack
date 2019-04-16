ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :github_name

  form do |f|
    f.inputs 'Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :github_name
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
    column :created_at
    column :updated_at

    actions
  end

  filter :id
  filter :email
  filter :github_name
  filter :first_name
  filter :last_name
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :github_name
      row :created_at
      row :updated_at
    end
  end
end
