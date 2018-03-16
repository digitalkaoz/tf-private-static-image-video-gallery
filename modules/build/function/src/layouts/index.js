import React from 'react'
import Header from '../components/Header'
import Menu from '../components/Menu'
import Footer from '../components/Footer'
import Helmet from 'react-helmet';
import PropTypes from 'prop-types';

import '../assets/scss/main.scss'

const initialStyle = {
    background: '#242943',
    display:'none'
};

class Template extends React.Component {

    constructor(props) {
        super(props)
        this.state = {
            isMenuVisible: false,
            loading: 'is-loading'
        }
        this.handleToggleMenu = this.handleToggleMenu.bind(this)
    }

    componentDidMount () {
        this.timeoutId = setTimeout(() => {
            this.setState({loading: ''});
        }, 100);
    }

    componentWillUnmount () {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId);
        }
    }

    handleToggleMenu() {
        this.setState({
            isMenuVisible: !this.state.isMenuVisible
        })
    }

    render() {
        const { children } = this.props;

        return (
            <div className={`body ${this.state.loading} ${this.state.isMenuVisible ? 'is-menu-visible' : ''}`}>
                <Helmet>
                    <meta name="theme-color" content={initialStyle.background}/>
                </Helmet>
                <div id="wrapper">
                    <Header shortName={this.props.data.site.siteMetadata.shortcode} onToggleMenu={this.handleToggleMenu} />
                    {children()}
                    <Footer author={this.props.data.site.siteMetadata.author} />
                </div>
                <Menu onToggleMenu={this.handleToggleMenu} folders={this.props.data.allMarkdownRemark.edges} />
            </div>
        )
    }
}

Template.propTypes = {
    children: PropTypes.func
};

export const query = graphql`
    query LayoutQuery {
        site {
            siteMetadata {
                author
                shortcode
            }
        }
        allMarkdownRemark {
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
`;

export default Template
