feature "Removing content without a redirect from Publisher", publisher: true do
  include PublisherHelpers

  let(:title) { title_with_timestamp }
  let(:slug) { slug_with_timestamp }

  scenario "Unpublishing an artefact" do
    given_a_published_artefact_with_subpages
    and_i_remove_the_published_artefact_with_no_redirect
    then_visiting_the_artefact_gives_a_410_gone_on_gov_uk
    and_visiting_a_subpage_gives_a_404_on_gov_uk
  end

  private

  def given_a_published_artefact_with_subpages
    create_publisher_artefact(slug: slug, title: title, format: "Guide")

    add_part_to_artefact(title: title_with_timestamp)
    @subpart_slug = add_part_to_artefact(title: title_with_timestamp)

    publish_artefact

    @published_url = find_link("View this on the GOV.UK website")[:href]
    wait_for_artefact_to_be_viewable(@published_url)
  end

  def and_i_remove_the_published_artefact_with_no_redirect
    switch_to_tab "Unpublish"

    page.accept_confirm do
      click_button "Unpublish"
    end

    expect(page).to have_content("Content unpublished")
  end

  def then_visiting_the_artefact_gives_a_410_gone_on_gov_uk
    reload_url_until_status_code(@published_url, 410, keep_retrying_while: [200])

    visit(@published_url)
    expect(page).to have_content("gone")
  end

  def and_visiting_a_subpage_gives_a_404_on_gov_uk
    reload_url_until_status_code(subpage_url, 404, keep_retrying_while: [200])
  end

  def subpage_url
    [@published_url, @subpart_slug].join("/")
  end
end
