# gotenberg

According to the official documentation, Gotenberg is a Docker-powered stateless API for PDF files. It offers a developer-friendly API that utilizes powerful tools like Chromium and LibreOffice to convert various document formats (such as HTML, Markdown, Word, Excel, and more) into PDF files and beyond. The gotenberg gem is a simple Ruby client for interacting with this API. Gotenberg provides multiple APIs for tasks such as converting HTML to PDF, URL to PDF, Markdown to PDF, and more.

Currently, this gem only supports the HTML conversion to PDF and health endpoint APIs. This gem seamlessly integrates the Rails asset pipeline with Gotenberg's requirements for HTML and assets and includes useful helper methods for assets which can be used in `.erb` files or other Ruby classes.

Please note that Gotenberg needs to be deployed on your server or VPC and can function as a stateless, central PDF generation engine for all of your applications. For more information and installation guides, please visit the [official website](https://gotenberg.dev).

**High-level flow diagram:**
![Alt text](./docs/diagram.png)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add gotenberg
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install gotenberg
```

In your `Gemfile`

```bash
gem 'gotenberg'
```

## Usage

```ruby
    client = Gotenberg::Client.new(ENV.fetch('GOTENBERG_ENDPOINT', nil))
    htmls = {
        index: "<h1> Body Html String </h1>",
        header: "<h1> Header Html String </h1>",
        footer: "<h1> Footer Html String </h1>"
    }

    asset_paths = [
        goten_static_asset_path('logo.svg'),
        goten_static_asset_path('gotenberg.png'),
        goten_compiled_asset_path('pdf/pdf.css'),
        goten_compiled_asset_path('pdf/pdf.js')
    ]
    properties = {
        paperWidth: '8.27',
        paperHeight: '11.7',
        marginTop: 10,
        marginBottom: 15,
        marginLeft: 10,
        marginRight: 10
        preferCssPageSize: false,
        printBackground: false,
        omitBackground: false,
        landscape: false,
        scale: 1.0
      }
    # All the properties supported by the gotenberg can be a property. Check official gotenberg docs for more info
    pdf_content = client.html(htmls, asset_paths, properties)
```

### Important Notes:

1. The keys must be exactly `index`, `header` and `footer`
2. `goten_static_asset_path` will return the absolute path to the static assets inside the `app/assets/` based on the extension.
3. `goten_compiled_asset_path` will return the absolute path to the precompiled assets inside the `public/assets`
4. `goten_asset_base64` will return the base64 encoded of the assets.
5. All these methods will be available automatically in the `.erb` files but if you need in the `.rb` files, then you will need to include `include Gotenberg::Helper`
6. Both `header` and `footer` have to be a complete HTML document

   1. `header.html`

   ```html
   <html>
     <head> </head>
     <body>
       <h1>Header</h1>
     </body>
   </html>
   ```

   2. `footer.html`

   ```html
   <html>
     <head>
       <style>
         body {
           font-size: 8rem;
           margin: 4rem auto;
         }
       </style>
     </head>
     <body>
       <p>
         <span class="pageNumber"></span> of <span class="totalPages"></span>
       </p>
     </body>
   </html>
   ```

   The following classes allow you to inject printing values:

   3. `date`: formatted print date
   4. `title`: document title
   5. `pageNumber`: current page number
   6. `totalPage`: total pages in the document

7. Header and Footer Limitations([source](https://gotenberg.dev/docs/6.x/html)):
   1. JavaScript is not executed
   2. external resources are not loaded
   3. the CSS properties are independant of the ones used in the `index.html` file
   4. `footer.html` CSS properties override the ones from `header.html`
   5. only fonts installed in the Docker image are loaded (see the fonts section)
   6. images only work using a base64 encoded source (`<img src="data:image/png;base64, iVBORw0K... />`)
   7. `background-color` and `color` CSS properties require an additional `-webkit-print-color-adjust: exact` CSS property in order to work
8. Basic Authentication
   1. `GOTENBERG_ENDPOINT='http://localhost:3000'`
   2. `GOTENBERG_API_BASIC_AUTH_USERNAME='username'`
   3. `GOTENBERG_API_BASIC_AUTH_PASSWORD='password'`

9. Fonts
	1. Use `Base64` encoding so that the font file is embedded directly in the CSS file, eliminating the need for an external font file.
   ```html
      Example:
      @font-face {
        font-family: "AvenirNextLTPro-Regular";
        src: url('AvenirNextLTPro-Regular.otf?base64, <base64_font_data>') format('opentype');
       }
   ```
      2.Use `goten_static_asset_path` to generates a URL or path to the static version of the asset, typically in its original form without any modifications from the build process. It points to the location of the raw, uncompiled version of the font files.
   ```html
      Example:
      goten_static_asset_path('AvenirNextLTPro-Regular.otf'),
   ```

10. Styling
	1. By default, Pdf Layout has 1 inch margin in all the sides, to modify use `@page` css property.
    ```html
	   Example:
	   @page {
	    margin-top: 100px;
	    margin-bottom: 60px;
	   }
    ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SELISEdigitalplatforms/gotenberg.git
