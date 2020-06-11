
class DataBoxAPI

  constructor: (props) ->
    console.debug "PublishAPI::constructor"
    @on_api_error = props.on_api_error or (response) ->
    return @


  get_base_url: ->
    return document.URL.split("?")[0]


  get_api_url: (endpoint) ->
    ###
     * Build API URL for the given endpoint
     * @param {string} endpoint
     * @returns {string}
    ###
    api_endpoint = "view"
    url = @get_base_url()
    # we also pass back eventual query parameters to the API
    params = location.search
    return "#{url}/#{api_endpoint}/#{endpoint}#{params}"


  fetch_querytypes: ->
    ###
     * Fetch querytypes from the server
     * @returns {Promise}
    ###
    return @get_json "query_types",
      method: "GET"


  get_json: (endpoint, options) ->
    ###
     * Fetch Ajax API resource from the server
     * @param {string} endpoint
     * @param {object} options
     * @returns {Promise}
    ###
    options ?= {}

    method = options.method or "POST"
    data = JSON.stringify(options.data) or "{}"
    on_api_error = @on_api_error

    url = @get_api_url endpoint
    init =
      method: method
      headers:
        "Content-Type": "application/json"
        "X-CSRF-TOKEN": @get_csrf_token()
      body: if method is "POST" then data else null
      credentials: "include"
    console.info "DataBoxAPI::fetch:endpoint=#{endpoint} init=",init
    request = new Request(url, init)
    fetch(request)
    .then (response) ->
      if not response.ok
        return Promise.reject response
      return response
    .then (response) ->
      return response.json()
    .catch (response) ->
      on_api_error response
      return response


  get_csrf_token: () ->
    ###
     * Get the plone.protect CSRF token
     * Note: The fields won't save w/o that token set
    ###
    return document.querySelector("#protect-script").dataset.token


export default DataBoxAPI
