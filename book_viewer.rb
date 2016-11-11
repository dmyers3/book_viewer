require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(chapter)
    chapter.split("\n\n").each_with_index.map do |line, index| 
      "<p id=paragraph#{index}>#{line}</p>" 
    end.join
  end
  
  def bold_query(paragraph, query)
    paragraph.gsub(query, "<strong>#{query}</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"
  
  @chapter = File.read("data/chp#{params[:number]}.txt")
  
  erb :chapter
end

get "/show/:name" do
  params[:name]
end

get "/search" do
  @results = search(params[:query] || "")
  erb :search
end

not_found do
  redirect "/"
end

# input - string
# output - chapters that contain string, or message if none found

# search every chapter and select it if word is found
# don't display results when first loading page
#   - display nothing if params[:query] == nil

def search(word)
  num_chapters = Dir.glob("data/chp*").count
  results = []
  1.upto(num_chapters) do |chapter_num|
    matches = {}
    chapter_paragraphs = File.read("data/chp#{chapter_num}.txt").split("\n\n")
    chapter_paragraphs.each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(word)
    end
    results << {name: @contents[chapter_num - 1], number: chapter_num,
                paragraphs: matches} if matches.any?
  end
  results
end

