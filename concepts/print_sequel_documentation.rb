require "terminal-table"
rows = [
  %w[Argument Definition],
  :separator,
  [":default", "The default value for the column."],
  :separator,
  [":index", <<-DOCS],
Create an index on this column.
If given a hash, use the hash as the options for the index.
DOCS
  :separator,
  [":null", <<-DOCS],
Mark the column as allowing NULL values (if true)
Notot allowing NULL values (if false).
If unspecified, will default to whatever the database default is (usually true).
DOCS
  :separator,
  [":primary_key", <<-DOCS],
Mark this column as the primary key.
This is used instead of the primary key method if you want a non-autoincrementing primary key.
DOCS
  :separator,
  [
    ":primary_key_constraint_name",
    "The name to give the primary key constraint."
  ],
  :separator,
  [":type", <<-DOCS],
Overrides the type given as the method name or a separate argument.
Not usually used by column itself, but often by other methods such as primary_key or foreign_key.
DOCS
  :separator,
  [":unique", <<-DOCS],
Mark the column as unique.
Generally has the same effect as creating a unique index on the column.
DOCS
  :separator,
  [":unique_constraint_name", "The name to give the unique constraint."],
  :separator
]

table = Terminal::Table.new rows: rows
puts table
