import React from 'react'
import Helmet from 'react-helmet'
import get from 'lodash/get'
import BannerLanding from '../components/BannerLanding';
import Gallery from '../components/Gallery';

class BlogPostTemplate extends React.Component {
    render() {
        const post = this.props.data.markdownRemark;
        const siteTitle = get(this.props, 'data.site.siteMetadata.title');
        const main = post.frontmatter.images[Math.floor(Math.random() * post.frontmatter.images.length)];
        const images = post.frontmatter.images;

        return <div>
            <Helmet title={`${post.frontmatter.title} | ${siteTitle}`}>
            </Helmet>
            <BannerLanding name={post.frontmatter.title} image={main} content={post.html}
                           date={post.frontmatter.date}/>
            <div id="main">
                <section id="one">
                    <div className="box alt">
                        <Gallery images={images} showThumbnails={true} />
                    </div>
                </section>
            </div>
            <hr/>
        </div>
    }
}

export default BlogPostTemplate

export const pageQuery = graphql`
    query BlogPostByPath($path: String!) {
        site {
            siteMetadata {
                title
            }
        }
        markdownRemark(frontmatter: {path: {eq: $path}}) {
            id
            html
            excerpt
            frontmatter {
                title
                date(formatString: "DD MMMM, YYYY")
                images {
                    src
                    srcSet
                }
            }
        }
    }
`;
