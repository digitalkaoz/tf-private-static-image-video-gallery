import React from 'react'
import Link from 'gatsby-link'
import Helmet from 'react-helmet'
import Banner from '../components/Banner'

class HomeIndex extends React.Component {

    randomImage(node) {
        const images = node.images.filter(image => !image.src.endsWith('.mp4'));

        return images[Math.floor(Math.random() * images.length)].src
    }

    render() {
        const siteTitle = this.props.data.site.siteMetadata.title;
        const siteDescription = this.props.data.site.siteMetadata.description;
        const folders = this.props.data.allMarkdownRemark.edges;

        return (
            <div>
                <Helmet>
                    <title>{siteTitle}</title>
                    <meta name="description" content={siteDescription} />
                </Helmet>

                <Banner title={siteTitle} description={siteDescription}/>

                <div id="main">
                    <section id="one" className="tiles">
                        {folders.map(folder =>
                            <article key={folder.node.frontmatter.title} style={{backgroundImage: `url("${this.randomImage(folder.node.frontmatter)}")`}}>
                                <header className="major">
                                    <Link to={folder.node.frontmatter.path} className="link primary" >
                                        <h3>{folder.node.frontmatter.title}</h3>
                                        <p>{folder.node.excerpt}</p>
                                    </Link>
                                </header>
                            </article>
                        )}
                    </section>
                </div>

            </div>
        )
    }
}

export default HomeIndex

export const pageQuery = graphql`
    query PageQuery {
        site {
            siteMetadata {
                title
                description
            }
        }
        allMarkdownRemark {
          edges {
            node {
              frontmatter {
                path
                title
                images {
                  src
                  srcSet
                }
              }
              excerpt
            }
          }
        }
    }
`