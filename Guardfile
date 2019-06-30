guard :minitest do
  watch(%r{^test/(.*)\/?(.*)_test\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { 'test/time_range_extractor_test.rb' }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
end

guard :rubocop, keep_failed: false do
  watch(%r{.+\.rb$})
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end

guard 'reek' do
  watch(%r{.+\.rb$})
  watch('.reek')
end
