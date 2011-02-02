require 'coulda'
require 'json'

module Coulda
  module WebSteps
    # Creates an object using a factory_girl factory and creates a Given step that reads like
    # "Given a gi_joe with a name of 'Blowtorch' and habit of 'swearing'"
    # @param factory_name A Symbol or String for the name of the factory_girl factory to use
    # @param args Arguments to supply to the *factory_name* factory_girl factory
    def given_a(factory_name, args = {})
      Given "a #{factory_name} #{humanize args}" do
        args.each do |key, value|
          if value.is_a? Symbol
            instance_var_named_value = instance_variable_get("@#{value}")
            args[key] = instance_var_named_value if instance_var_named_value
          end
        end
        model = Factory(factory_name.to_sym, args)
        instance_variable_set("@#{factory_name}", model)
      end
    end

    # Asserts that the current page has *content* and a Then step that reads like 
    # "Then I should see 'You're not cookin!'"
    # @param content The content to check for.
    def then_i_should_see(content)
      Then "I should see '#{content}'" do
        assert page.has_content?(content), "Page doesn't have \"#{content}\""
      end
    end

    # Asserts that the current page does not have *content* and a Then step that reads like
    # "Then I should not see 'Who'd like a body massage?'"
    # @param content The content to check for.
    def then_i_should_not_see(content)
      Then "I should not see '#{content}'" do
        assert !page.has_content?(content), "Page has \"#{content}\""
      end
    end

    # Asserts that the response contains JSON, parses it into a hash, stores it in *@json*, and
    # creates a "Then I should get a JSON response" step
    def then_i_should_have_a_json_response
      Then "I should get a JSON response" do
        assert_equal "application/json", @response.content_type
        @json = JSON.parse(@response.body)
      end
    end

    # Asserts the HTTP status code to be *status* and creates a step like 
    # "Then I should receive a 200 response"
    # @param status The expected HTTP status code as a Fixnum
    def then_i_should_receive_a(status)
      Then "I should receive a #{status} response" do
        assert_equal status, @response.status
      end
    end

    # Asserts that the a flash is on the page, that it has a class of *level* and the expected *message*.
    # and creates a step like "Then I should see the flash error 'PORKCHOP SANDWICHES'"
    # @param level The expected class of the flash on the page: "notice" or "error"
    # @param message The expected message in the flash
    def then_i_should_see_flash(level, message)
      Then "I should see the flash #{level} '#{message}'" do
        assert find("#flash").find(".#{level}").has_content? message
      end
    end

    def then_i_should_not_be_on(path, *args)
      humanized_path = path.to_s.gsub /_/, " " 
      Then "I should not be on #{humanized_path}" do
        instance_var_args = args.inject([]) do |new_args, arg|
          new_args << instance_variable_get("@#{arg}")
        end
        assert current_path != __send__(path, *instance_var_args), "I am on '#{current_path}' but I shouldn't be"
      end
    end

    def then_i_should_be_on(path, *args)
      humanized_path = path.to_s.gsub /_/, " " 
      Then "I should be on #{humanized_path}" do
        instance_var_args = args.inject([]) do |new_args, arg|
          new_args << instance_variable_get("@#{arg}")
        end
        assert current_path, __send__(path, *instance_var_args)
      end
    end

    # Visits the page specified by *path* and creates a step like 
    # "When I visit the pork chop sandwich kitchen"
    # @param path A Symbol giving the name of the helper to invoke to generate a path
    # @param args Symbols representing the names of member variables set in previous steps 
    # (see #{WebSteps#given_a} method)
    def when_i_visit(path, *args)
      humanized_path = path.to_s.gsub /_/, " " 
      When "I visit the #{humanized_path}" do
        instance_var_args = args.inject([]) do |new_args, arg|
          new_args << instance_variable_get("@#{arg}")
        end
        visit __send__(path, *instance_var_args)
      end
    end

    # Clicks the link specified by *link* and generates a step like
    # "When I click the link 'Get the f**k out!'"
    # @param link The name of the link to click
    def when_i_click_link(link)
      When "I click the link '#{link}'" do
        click_link link.to_s
      end
    end

    # Clicks the button specified by *button* and generates a step like
    # "When I click the button 'What are you doing?!'"
    # @param button The name of the button to click
    def when_i_click_button(button)
      When "I click the button '#{button}'" do
        click_button button.to_s
      end
    end

    private

    def humanize(hash)
      str = ""
      if !hash.empty?
        str << "with "
        hash.each_with_index do |kv, idx|
          str << choose_conjunction_given(hash, :and_idx => idx)
          key, value = kv.first, kv.second
          str << "#{key} of '#{value}'"
        end
        str
      end
    end

    def choose_conjunction_given(args_hash, args = {}) 
      idx = args[:and_idx]
      conj = ""
      if idx > 0
        if args_hash.length > 2
          if idx < args_hash.length - 1
            conj = ", " 
          else
            conj = ", and "
          end
        else
          conj = " and "
        end
      end
      conj
    end
  end
end
