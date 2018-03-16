require('dotenv').config()

const config = JSON.parse(process.env.CONFIG || "{}");

module.exports = {
    siteMetadata: {
        title: config.title,
        author: config.author,
        description: config.subline,
        shortcode: config.shortcode
    },
    pathPrefix: '/',
    plugins: [
        'gatsby-plugin-sass',
        'gatsby-transformer-remark',
        {
            resolve: 'gatsby-source-filesystem',
            options: {
                path: `${__dirname}/src/posts`,
                name: 'posts',
            },
        },
        'gatsby-plugin-react-helmet',
        {
            resolve: 'gatsby-plugin-manifest',
            options: {
                name: config.title,
                short_name: config.shortcode,
                start_url: '/',
                background_color: '#242943',
                theme_color: '#242943',
                display: 'minimal-ui',
                icons: [
                    {
                        // Everything in /static will be copied to an equivalent
                        // directory in /public during development and build, so
                        // assuming your favicons are in /static/favicons,
                        // you can reference them here
                        src: '/favicons/android-chrome-192x192.png',
                        sizes: '192x192',
                        type: 'image/png',
                    },
                    {
                        src: '/favicons/android-chrome-512x512.png',
                        sizes: '512x512',
                        type: 'image/png',
                    },
                ],
            },
        },
        {
            resolve: 'gatsby-plugin-offline',
            options: {
                staticFileGlobs: [
                    `${__dirname}/public/**/*.{js,css,woff2}`,
                    `${__dirname}/public/manifest.json`,
                    `${__dirname}/public/offline-plugin-app-shell-fallback/index.html`,
                ],
                stripPrefix: __dirname + '/public',
                navigateFallback: '/offline-plugin-app-shell-fallback/index.html',
                // Only match URLs without extensions.
                // So example.com/about/ will pass but
                // example.com/cheeseburger.jpg will not.
                // We only want the service worker to handle our "clean"
                // URLs and not any files hosted on the site.
                navigateFallbackWhitelist: [/index\.html/],
                cacheId: 'gatsby-plugin-offline',
                // Do cache bust JS URLs until can figure out how to make Webpack's
                // URLs truely content-addressed.
                dontCacheBustUrlsMatching: /(.\w{8}.woff2)/, //|-\w{20}.js)/,
                runtimeCaching: [
                    {
                        // Add runtime caching of images.
                        urlPattern: /\.(?:png|jpg|jpeg|webp|svg|gif|tiff)$/,
                        handler: 'fastest',
                    },
                ],
                skipWaiting: false,
            }
        }
    ],
};
