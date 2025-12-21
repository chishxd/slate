# frozen_string_literal: true

require_relative "slate/version"
require "kramdown"
require 'kramdown-parser-gfm'

module Slate
  class Error < StandardError; end
  class CLI
    # This method is the MAIN method... Refactored from bin/slate
    def self.run(path)
      path = File.expand_path(path)
      if File.file?(path)
        process_file(path)
      elsif File.directory?(path)
        process_directory(path)
      else
        puts "Error: #{path} Is neither a file, nor a directory"
      end
    end

    def self.convert(md_content, title)
      raw_html = Kramdown::Document.new(md_content, input: 'GFM').to_html

      final_html = "<head>\n<title> #{title} </title>\n <link href='style.css' rel='stylesheet'>\n</head>\n<body class='markdown-body'>\n#{raw_html}\n</body>"

      return final_html
    end

    def self.copy_css(dest)  
      style_path = File.join(__dir__, '..', 'style.css')
      FileUtils.cp(style_path, dest)
    end

    def self.save_file(path)
      content = File.read(path)
      filename = File.basename(path, ".*")
      dir = File.dirname(path)

      output_path = File.join(dir, "#{filename}.html")
      final_html = convert(content, filename)
      File.write(output_path, final_html)
      puts "Saved #{filename}.html"
    end

    def self.process_file(path)
      puts "Argument seems to be a single file, Parsing it"
      dest = File.dirname(path)
      copy_css(dest)
      save_file(path)
    end

    def self.process_directory(path)
      puts "Found a directory, gotta check all .md files!"

      copy_css(path)
  
      files = Dir.glob(File.join(path, "*.md"))

      files.each do |file|
        save_file(file)
      end
    end

  end
end
