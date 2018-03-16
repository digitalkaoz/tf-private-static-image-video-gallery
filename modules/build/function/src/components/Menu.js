import React from 'react'
import Link from 'gatsby-link'
import PropTypes from 'prop-types';

const Menu = (props) =>
    <nav id="menu">
        <div className="inner">
            <ul className="links">
                <li><Link onClick={props.onToggleMenu} to="/">Home</Link></li>
                { process.env.NODE_ENV !== 'production' && <li><Link onClick={props.onToggleMenu} to="/elements">Elements</Link></li>}
            </ul>
            <ul className="actions vertical">
                {props.folders.map((folder) => <li key={folder.node.frontmatter.title}><Link onClick={props.onToggleMenu} to={folder.node.frontmatter.path}>{folder.node.frontmatter.title}</Link></li>)}
            </ul>
        </div>
        <a className="close" onClick={props.onToggleMenu} href="javascript:;">Close</a>
    </nav>;

Menu.propTypes = {
    onToggleMenu: PropTypes.func,
    folders: PropTypes.array
};

export default Menu
