const _ = require('lodash')
const path = require('path')

exports.createPages = ({graphql, boundActionCreators}) => {
    const {createPage} = boundActionCreators

    return new Promise((resolve, reject) => {
        const blogPost = path.resolve('./src/templates/blog-post.js')
        resolve(
            graphql(
                `
      {
        allMarkdownRemark(limit: 1000) {
          edges {
            node {
              frontmatter {
                path
              }
            }
          }
        }
      }
    `
            ).then(result => {
                if (result.errors) {
                    reject(result.errors)
                }

                // Create blog posts pages.
                _.each(result.data.allMarkdownRemark.edges, edge => {
                    createPage({
                        path: edge.node.frontmatter.path,
                        component: blogPost,
                        context: {
                            path: edge.node.frontmatter.path,
                        },
                    })
                })
            })
        )
    })
};