module RailsBlogEngine
  module ApplicationHelper
    # Process a block of text as Markdown, using our filters, and sanitize
    # any usafe HTML.  You can pass <code>:trusted? => true</code> to allow
    # images and links without nofollow.
    def markdown(md_text, options={})
      config = sanitize_config(options[:trusted?] || false)
      filtered = Filters.apply_all_to(md_text)
      Sanitize.clean(RDiscount.new(filtered, :smart).to_html, config).html_safe
    end

    # The URL of our Atom feed. Rails refuses to generate this in any simple
    # fashion, so we do it manually.
    def feed_url
      root_url + "posts.atom"
    end

    # Get extra HTML classes for the specified comment.
    def comment_classes(comment)
      comment.state.sub(/\A(filtered|marked)_as_/, '')
    end

    # Generate HTML describing the author of a comment.
    def comment_author_html(comment)
      if comment.author_url && !comment.author_url.blank?
        link_to comment.author_byline, comment.author_url, :rel => "nofollow"
      else
        comment.author_byline
      end
    end

    protected

    # Choose a configuration for the Sanitizer gem.
    def sanitize_config(trusted)
      if trusted then CUSTOM_RELAXED_CONFIG else Sanitize::Config::BASIC end
    end

    # Allow a few extra tags, mostly for use by our source-code highlighting
    # filter.
    def self.customize_sanitize_config(sanitize_config)
      new_config = {}
      sanitize_config.each {|k,v| new_config[k] = v.dup }
      new_config[:elements] += ['div', 'span']
      new_config[:attributes].merge!('div' => ['class'], 'span' => ['class'])
      new_config
    end

    # The Sanitize configuration used for trusted posters.
    CUSTOM_RELAXED_CONFIG = customize_sanitize_config(Sanitize::Config::RELAXED)
  end
end
