class BreadcrumbList
  def initialize
    @breadcrumbs = []
  end

  def add(link, title, section)
    @breadcrumbs << OpenStruct.new(link: link, title: title.html_safe, section: section)
  end

  def each
    @breadcrumbs.each do |breadcrumb|
      yield breadcrumb
    end
  end

  def last
    @breadcrumbs.last
  end

  def first
    @breadcrumbs.first
  end

  def active_section?(section)
    if @breadcrumbs.first && @breadcrumbs.first.section == section
      'class="active"'.html_safe
    end
  end
end
