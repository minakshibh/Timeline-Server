module DelayedPaperclip
  module InstanceMethods

    def enqueue_post_processing_for name
      DelayedPaperclip.enqueue(self.class.name, self.id.to_param, name.to_sym)
    end

  end
end
