require_relative 'slate/version'
require 'kramdown'
require 'kramdown-parser-gfm'
require 'optparse'

module Slate
  class Error < StandardError; end

  Options = Struct.new(:output_dir)
  # The main class to rule them all
  class CLI
    # This method is the MAIN method... Refactored from bin/slate
    def self.run(argv)
      options = Options.new(nil)

      OptionParser.new do |opts|
        opts.banner = 'Usage: slate [options] <file_or_directory>'

        opts.on('-o', '--output DIR', 'Specify the output direc1tory') do |dir|
          options.output_dir = dir
        end

        opts.on('-v', '--version', 'Show current version') do |_ver|
          puts Slate::VERSION
          exit
        end

        opts.on('-h', '--help', 'View Help') do
          puts opts
          exit
        end
      end.parse!(argv)

      path = argv.first
      if path.nil?
        puts 'Error: You must provide a file or directory.'
        puts opt_parser
        exit
      end

      path = File.expand_path(path)
      if File.file?(path)
        process_file(path, options)
      elsif File.directory?(path)
        process_directory(path, options)
      else
        puts "Error: #{path} Is neither a file, nor a directory"
      end
    end

    def self.convert(md_content, title)
      raw_html = Kramdown::Document.new(md_content, input: 'GFM').to_html

      "<head>\n<title> #{title} </title>\n <link href='style.css' rel='stylesheet'>\n</head>\n<body class='markdown-body'>\n#{raw_html}\n</body>"
    end

    def self.copy_css(dest)
      FileUtils.mkdir_p(dest)
      style_path = File.join(__dir__, '..', 'style.css')
      FileUtils.cp(style_path, dest)
    end

    def self.save_file(path, options)
      content = File.read(path)
      filename = File.basename(path, '.*')
      dir = options.output_dir || File.dirname(path)

      FileUtils.mkdir_p(dir)
      output_path = File.join(dir, "#{filename}.html")
      final_html = convert(content, filename)
      File.write(output_path, final_html)
      puts "Saved #{filename}.html"
    end

    def self.process_file(path, options)
      puts 'Argument seems to be a single file, Parsing it'
      dest = options.output_dir || File.dirname(path)
      copy_css(dest)
      save_file(path, options)
    end

    def self.process_directory(path, options)
      puts 'Found a directory, gotta check all .md files!'
      dir = options.output_dir || path
      copy_css(dir)

      files = Dir.glob(File.join(path, '*.md'))

      files.each do |file|
        save_file(file, options)
      end
      puts "Done! Processed #{files.count} files."
    end
  end
end
