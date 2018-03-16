import React from 'react'
import Link from 'gatsby-link'
import PropTypes from 'prop-types';

const Header = ({shortName, onToggleMenu}) =>
    <header id="header" className="alt">
        <Link to="/" className="logo"><strong>{shortName}</strong> <span>by HTML5 UP</span></Link>
        <nav>
            <a className="menu-link" onClick={onToggleMenu} href="javascript:;">Menu</a>
        </nav>
    </header>

Header.propTypes = {
    onToggleMenu: PropTypes.func,
    shortName: PropTypes.string
};

export default Header
