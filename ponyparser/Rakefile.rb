task :default => ["ponyparser.pony", :test]

file "ponyparser.pony" => ["ponyparser.in", "../rdparser/convert.rb"] do |t|
    sh "ruby #{t.prerequisites[1]} #{t.prerequisites[0]} >#{t.name}"
end

task :test do
    Dir.chdir("test") do 
        sh "ponyc-d"
        sh "./test"
    end
end