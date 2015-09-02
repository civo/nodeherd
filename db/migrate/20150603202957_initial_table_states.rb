class InitialTableStates < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :hostname
      t.text :lshw_information
      t.integer :cpu_cores
      t.integer :ram_gb
      t.integer :disk_space
      t.integer :disk_free
      t.timestamps
    end

    create_table :server_tags do |t|
      t.integer :server_id
      t.string :tag
      t.timestamps
    end

    create_table :scripts do |t|
      t.string :name
      t.integer :replaced_by
      t.string :interpreter
      t.integer :timeout
      t.text :content
      t.binary :file_1, limit: 100.megabyte
      t.binary :file_2, limit: 100.megabyte
      t.binary :file_3, limit: 100.megabyte
      t.binary :file_4, limit: 100.megabyte
      t.binary :file_5, limit: 100.megabyte
      t.timestamps
    end

    create_table :users do |t|
      t.string :username
      t.string :password_hash
      t.string :password_salt
      t.string :name
      t.string :token
      t.timestamps
    end

    create_table :statistics do |t|
      t.integer :server_id
      t.string :uptime
      t.float :load_percentage
      t.integer :free_memory_mb
      t.timestamps
    end

    create_table :packages do |t|
      t.string :name
      t.string :version
      t.text :information
      t.timestamps
    end

    create_table :package_updates do |t|
      t.integer :server_id
      t.integer :package_id
      t.boolean :applied
      t.boolean :security
      t.timestamps
    end

    create_table :queues do |t|
      t.string :action
      t.integer :server_id
      t.integer :package_id
      t.integer :script_id
      t.boolean :completed
      t.boolean :success
      t.text :output
      t.timestamps
    end

  end
end
