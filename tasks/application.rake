desc 'Run the app'
task :s do
  system "rackup -p 3003 -o 0.0.0.0"
end
