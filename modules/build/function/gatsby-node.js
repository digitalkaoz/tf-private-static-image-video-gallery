const nodePath = require(`path`);

exports.createPages = ({ graphql, boundActionCreators }) => {
    const { createPage } = boundActionCreators

    return new Promise((resolve, reject) => {
        const blogPostTemplate = nodePath.resolve(`src/templates/blog-post.js`)

        graphql(
            `{
                allMarkdownRemark(limit: 1000) {
                    edges {
                        node {
                            frontmatter {
                                path
                                title
                            }
                        }
                    }
                }
            }
        `
        ).then(result => {
            if (result.errors) {
                console.log(result.errors);
                reject();
            }

            // Create blog posts pages.
            result.data.allMarkdownRemark.edges.forEach(edge => {
                const {path, title} = edge.node.frontmatter;
                createPage({
                        path,
                        component: blogPostTemplate,
                        context: {
                            title,
                            slug: path,
                        },
                    })
                }
            );

            resolve();
        })
    })
};