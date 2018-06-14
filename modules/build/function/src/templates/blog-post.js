import React from 'react'
import Helmet from 'react-helmet'
import get from 'lodash/get'
import BannerLanding from '../components/BannerLanding';
import Gallery from '../components/Gallery';

class BlogPostTemplate extends React.Component {
    randomImage(medias) {
        const images = medias.filter(image => !image.src.endsWith('.mp4'));

        return images[Math.floor(Math.random() * images.length)];
    }

    render() {
        const post = this.props.data.markdownRemark;
        const siteTitle = get(this.props, 'data.site.siteMetadata.title');
        const medias = post.frontmatter.images;
        const bannerImage = this.randomImage(medias);
        const contentMedia = medias.filter((image) => image.src !== bannerImage.src);

        return <div>
            <Helmet title={`${post.frontmatter.title} | ${siteTitle}`} />
            <BannerLanding name={post.frontmatter.title}
                           image={bannerImage}
                           content={post.html}
                           date={post.frontmatter.date}/>
            <div id="main">
                <section id="one">
                    <div className="box alt">
                        <Gallery images={contentMedia} showThumbnails={true} />
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
