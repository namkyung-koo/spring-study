-- Copyright 2004-2024 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

select coalesce(null, null) xn, coalesce(null, 'a') xa, coalesce('1', '2') x1;
> XN   XA X1
> ---- -- --
> null a  1
> rows: 1
