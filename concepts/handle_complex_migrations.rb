require "thor"
require "tty-prompt"
require "tty-file"
require "erb"
require "debug"

class YourCLI < Thor
  desc "generate_migration", "Generate a Sequel migration file"
  def generate_migration
    # Collect user input using TTY prompt
    migration_name = prompt.ask("Enter migration name:")
    migration_operations = collect_migration_operations

    # Render the migration template
    # template_content =
    #   render_migration_template(migration_name, migration_operations)

    # Generate the migration file
    # TTY::File.copy_file(
    #   base_path("lib/rephlex/templates/migration.erb"),
    #   base_path("db/migrations/#{timestamp}_#{migration_name}.rb")
    # ) { |content| template_content }

    # puts "Migration file created successfully!"
  end

  private

  def prompt
    @prompt ||= TTY::Prompt.new
  end

  def timestamp
    Time.now.strftime("%Y%m%d%H%M%S")
  end

  def collect_migration_operations
    migration_operations = []

    loop do
      operation = select_migration_operation

      case operation
      when "create_table"
        table_name = prompt.ask("Enter the table name:")
        migration_operations << "create_table(:#{table_name}) do"
        add_table_columns(migration_operations)
        migration_operations << "end"
      when "add_column"
        table_name = prompt.ask("Enter the table name:")
        column_name = prompt.ask("Enter the column name:")
        data_type = select_data_type
        migration_operations << "add_column(:#{table_name}, :#{column_name}, :#{data_type})"
      when "drop_table"
        table_name = prompt.ask("Enter the table name:")
        migration_operations << "drop_table(:#{table_name})"
      when "rename_table"
        old_name = prompt.ask("Enter the current table name:")
        new_name = prompt.ask("Enter the new table name:")
        migration_operations << "rename_table(:#{old_name}, :#{new_name})"
      when "exit"
        break
      end
    end

    migration_operations
  end

  def select_migration_operation
    prompt.select(
      "Select a migration operation:",
      cycle: true,
      filter: true
    ) do |menu|
      menu.choice "Create Table", "create_table"
      menu.choice "Add Column", "add_column"
      menu.choice "Drop Table", "drop_table"
      menu.choice "Rename Table", "rename_table"
      menu.choice "Exit", "exit"
    end
  end

  def add_table_columns(migration_operations)
    loop do
      column_name =
        prompt.ask("Enter the column name (or 'exit' to stop adding columns):")
      break if column_name == "exit"

      data_type = select_data_type
      migration_operations << "  column :#{column_name}, :#{data_type}"
    end
  end

  def select_data_type
    types_with_options = {
      "Integer" => {
        type: "Integer"
      },
      "String" => {
        type: "String",
        options: {
          "Size" => :size,
          "Fixed" => :fixed,
          "Text" => :text
        }
      },
      "Fixnum" => {
        type: "Fixnum"
      },
      "Bignum" => {
        type: "Bignum"
      },
      "Float" => {
        type: "Float"
      },
      "BigDecimal" => {
        type: "BigDecimal",
        options: {
          "Size" => :size
        }
      },
      "Date" => {
        type: "Date"
      },
      "DateTime" => {
        type: "Datetime"
      },
      "Time" => {
        type: "Time",
        options: {
          "Only Time" => :only_time
        }
      },
      "Numeric" => {
        type: "Numeric"
      },
      "TrueClass" => {
        type: "TrueClass"
      },
      "FalseClass" => {
        type: "FalseClass"
      }
    }

    type =
      prompt.select(
        "Select the data type:",
        types_with_options.keys,
        cycle: true,
        filter: true
      )
    options = types_with_options[type]&.fetch(:options, {})
    binding.break
    selected_options =
      options.each_with_object({}) do |(option_name, option_key), result|
        if option_name == "Fixed" || option_name == "Text"
          result[option_key] = prompt.yes?(
            "Do you want #{option_name.downcase}? (Y/n)"
          )
        else
          result[option_key] = prompt.ask("Enter the #{option_name.downcase}:")
        end
      end

    { type: types_with_options[type][:type], options: selected_options }
  end

  # def render_migration_template(migration_name, migration_operations)
  #   template_path = base_path("lib/rephlex/templates/migration.erb")
  #   template = ERB.new(File.read(template_path))
  #   template.result(binding)
  # end
end

YourCLI.start(ARGV)

class Migration < Rephlex::Command
  TYPES = %w[
    primary_key
    foreign_key
    Integer
    String
    File
    Fixnum
    Bignum
    Float
    BigDecimal
    Date
    DateTime
    Time
    Numeric
    TrueClass
    FalseClass
  ]

  def initialize(options)
    @options = options
  end

  def generate(verbose: true, input: $stdin, output: $stdout)
    @prompt = create_prompt(input, output)
    @verbose = verbose
    migration_name = @prompt.ask("Enter migration name:")
    migration_operations = collect_migration_operations

    TTY::File.create_file(
      base_path("db/migrations/#{timestamp}_#{migration_name}.rb"),
      render_migration_template(migration_name, migration_operations),
      verbose: @verbose
    )
  end

  def timestamp
    Time.now.strftime("%Y%m%d%H%M%S")
  end

  def collect_migration_operations
    migration_operations = []

    loop do
      operation =
        @prompt.select(
          "Select a migration operation:",
          %w[create_table add_column drop_table rename_table exit]
        )

      case operation
      when "create_table"
        table_name = @prompt.ask("Enter the table name:")
        migration_operations << "create_table :#{table_name} do"
        add_table_columns(migration_operations, table_name)
        migration_operations << "end"
      when "add_column"
        table_name = @prompt.ask("Enter the table name:")
        column_name = @prompt.ask("Enter the column name:")
        data_type = @prompt.ask("Enter the data type:")
        migration_operations << "add_column :#{table_name}, :#{column_name}, :#{data_type}"
      when "drop_table"
        table_name = @prompt.ask("Enter the table name:")
        migration_operations << "drop_table :#{table_name}"
      when "rename_table"
        old_name = @prompt.ask("Enter the current table name:")
        new_name = @prompt.ask("Enter the new table name:")
        migration_operations << "rename_table :#{old_name}, :#{new_name}"
      when "exit"
        break
      end
    end

    migration_operations
  end

  def add_table_columns(migration_operations, table_name)
    loop do
      column_name =
        @prompt.ask(
          "Enter the column name (or 'exit' to stop adding columns):"
        )
      break if column_name == "exit"

      data_type = @prompt.ask("Enter the data type for #{column_name}:")
      migration_operations << "  column :#{column_name}, :#{data_type}"
    end
  end

  def render_migration_template(migration_name, migration_operations)
    template_path = base_path("lib/rephlex/templates/migration.erb")
    template_content = File.read(template_path)

    template_content.gsub!("__MIGRATION_NAME__", migration_name)
    template_content.gsub!(
      "__MIGRATION_OPERATIONS__",
      migration_operations.join("\n")
    )

    template_content
  end

  def select_data_type
    TYPE_OPTIONS = {
      "String" => {
          "Size" => :size,
          "Fixed" => :fixed,
          "Text" => :text
      },
      "BigDecimal" => {
          "Size" => :size
      },
      "Time" => {
          "Only Time" => :only_time
      },
    }

    type =
      prompt.select(
        "Select the data type:",
        cycle: true,
        filter: true
      ) { |menu| types_with_options.map { |display_name, _| display_name } }

    options = types_with_options[type]&.fetch(:options, {})

    selected_options =
      options.each_with_object({}) do |(option_name, option_key), result|
        result[option_key] = prompt.ask(
          "Enter the #{option_name.downcase}:"
        )
      end

    { type: types_with_options[type][:type], options: selected_options }
  end
end
